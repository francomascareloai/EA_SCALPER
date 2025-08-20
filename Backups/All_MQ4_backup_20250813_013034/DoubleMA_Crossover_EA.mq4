//+------------------------------------------------------------------+
//|                                 DoubleMA_Crossover_EA.mq4        |
//|                                              Copyright © 2005    |
//|    Written by MrPip from idea of Jason Robinson for Eric         |                                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MrPip"
#include <stdlib.mqh>

extern int MagicNumber = 2222;

extern bool AccountIsMini = false;       // Change to true if trading mini account
extern bool MoneyManagement = false;     // Change to false to shutdown money management controls.
                                         // Lots = 1 will be in effect and only 1 lot will be open regardless of equity.
extern double TradeSizePercent = 5;      // Change to whatever percent of equity you wish to risk.
extern double Lots = 3;             // standard lot size. 
extern double MaxLots = 100;
//+---------------------------------------------------+
//|Indicator Variables                                |
//| Change these to try your own system               |
//| or add more if you like                           |
//+---------------------------------------------------+
extern int FastMA_Mode = 0;          //0=sma, 1=ema, 2=smma, 3=lwma, 4=LSMA
extern int FastMA_Period =   2;
extern int FastMA_Shift = 0;
extern int FastMA_AppliedPrice = 0;  // 0=close, 1=open, 2=high, 3=low, 4=median((h+l/2)), 5=typical((h+l+c)/3), 6=weighted((h+l+c+c)/4)
extern int SlowMA_Mode = 0;           //0=sma, 1=ema, 2=smma, 3=lwma, 4=LSMA
extern int SlowMA_Period =   5;
extern int SlowMA_Shift = 0;
extern int SlowMA_AppliedPrice = 0;  // 0=close, 1=open, 2=high, 3=low, 4=median((h+l/2)), 5=typical((h+l+c)/3), 6=weighted((h+l+c+c)/4)
extern int Fast_SlowSpreadEntry = 11;        // How many pips separation between MAs for signal
extern int Fast_SlowSpreadExit=0;        // How many pips separation between MAs for signal
extern int SignalCandle=1;
//+---------------------------------------------------+
//|Money Management                                   |
//+---------------------------------------------------+
extern double StopLoss = 250;       // Maximum pips willing to lose per position.
extern bool UseTrailingStop = true;
extern int TrailingStopType = 3;    // Type 1 moves stop immediately, Type 2 waits til value of TS is reached
extern double TrailingStop = 40;    // Change to whatever number of pips you wish to trail your position with.
extern double FirstMove = 20;       // Type 3  first level pip gain
extern double FirstStopLoss = 15;       // Move Stop to Breakeven
extern double SecondMove = 30;      // Type 3 second level pip gain
extern double SecondStopLoss = 20;      // Move stop to lock is profit
extern double ThirdMove = 40;       // type 3 third level pip gain
extern double TrailingStop3 = 20;   // Move stop and trail from there
extern int TakeProfit = 0;          // Maximum profit level achieved.
extern double Margincutoff = 800;   // Expert will stop trading if equity level decreases to that level.
extern int Slippage = 10;           // Possible fix for not getting closed    


//+---------------------------------------------------+
//|General controls                                   |
//+---------------------------------------------------+
string setup;
double lotMM;
int TradesInThisSymbol;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   setup="DoubleMA_Crossover_EA" + Symbol();
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
  }

//+------------------------------------------------------------------------+
//| LSMA - Least Squares Moving Average function calculation               |
//| LSMA_In_Color Indicator plots the end of the linear regression line    |
//| Modified to use any timeframe                                          |
//+------------------------------------------------------------------------+

double LSMA(int Rperiod,int prMode, int TimeFrame, int mshift)
{
   int i;
   double sum, price;
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
     switch (prMode)
     {
     case 0: price = iClose(NULL,TimeFrame,length-i+mshift);break;
     case 1: price = iOpen(NULL,TimeFrame,length-i+mshift);break;
     case 2: price = iHigh(NULL,TimeFrame,length-i+mshift);break;
     case 3: price = iLow(NULL,TimeFrame,length-i+mshift);break;
     case 4: price = (iHigh(NULL,TimeFrame,length-i+mshift) + iLow(NULL,TimeFrame,length-i+mshift))/2;break;
     case 5: price = (iHigh(NULL,TimeFrame,length-i+mshift) + iLow(NULL,TimeFrame,length-i+mshift) + iClose(NULL,TimeFrame,length-i+mshift))/3;break;
     case 6: price = (iHigh(NULL,TimeFrame,length-i+mshift) + iLow(NULL,TimeFrame,length-i+mshift) + iClose(NULL,TimeFrame,length-i+mshift) + iClose(NULL,TimeFrame,length-i+mshift))/4;break;
     }
     tmp = ( i - lengthvar)*price;
     sum+=tmp;
    }
    wt = sum*6/(length*(length+1));
    
    return(wt);
}

//+------------------------------------------------------------------+
//| CheckExitCondition                                               |
//| Check if any exit condition is met                               |
//+------------------------------------------------------------------+
bool CheckExitCondition(string TradeType)
{
   bool YesClose;
   double fMA, sMA;
   
   YesClose = false;
   if (FastMA_Mode == 4)
   {
     fMA = LSMA(FastMA_Period,FastMA_AppliedPrice,0,SignalCandle);
   }
   else
   {
     fMA = iMA(NULL, 0, FastMA_Period, FastMA_Shift, FastMA_Mode, FastMA_AppliedPrice, SignalCandle);
   }
   if (SlowMA_Mode == 4)
   {
     sMA = LSMA(SlowMA_Period,SlowMA_AppliedPrice,0,SignalCandle);
   }
   else
   {
     sMA = iMA(NULL, 0, SlowMA_Period, SlowMA_Shift, SlowMA_Mode, SlowMA_AppliedPrice, SignalCandle);
   }
    // Check for cross down
   if (TradeType == "BUY" && fMA - sMA < Fast_SlowSpreadExit*Point) YesClose = true;
   // Check for cross up
   if (TradeType == "SELL" && fMA - sMA > Fast_SlowSpreadExit*Point) YesClose = true;

   return (YesClose);
}

//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//| Check if entry condition is met                                  |
//+------------------------------------------------------------------+
bool CheckEntryCondition(string TradeType)
{
   bool YesTrade;
   double fMA, sMA;
   
   YesTrade = false;
   if (FastMA_Mode == 4)
   {
     fMA = LSMA(FastMA_Period,FastMA_AppliedPrice,0,SignalCandle);
   }
   else
   {
     fMA = iMA(NULL, 0, FastMA_Period, FastMA_Shift, FastMA_Mode, FastMA_AppliedPrice, SignalCandle);
   }
   if (SlowMA_Mode == 4)
   {
     sMA = LSMA(SlowMA_Period,SlowMA_AppliedPrice,0,SignalCandle);
   }
   else
   {
     sMA = iMA(NULL, 0, SlowMA_Period, SlowMA_Shift, SlowMA_Mode, SlowMA_AppliedPrice, SignalCandle);
   }
     // Check for cross up
   if (TradeType == "BUY" && fMA - sMA > Fast_SlowSpreadExit*Point)  YesTrade = true;
    // Check for cross down
   if (TradeType == "SELL" && fMA - sMA < Fast_SlowSpreadExit*Point ) YesTrade = true;
   
   return (YesTrade);
}
  

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//---- 


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
		OpenBuyOrder();
	}

   
	if(CheckEntryCondition("SELL"))
	{
		OpenSellOrder();
	}
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Functions beyond this point should not need to be modified       |
//| Eventually will be placed in include file                        |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| OpenBuyOrder                                                     |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
   int err,ticket;
   double myStopLoss = 0, myTakeProfit = 0;
   
   myStopLoss = 0;
   if ( StopLoss > 0 ) myStopLoss = Ask - StopLoss * Point ;
   myTakeProfit = 0;
   if (TakeProfit>0) myTakeProfit = Ask + TakeProfit * Point;
   ticket=OrderSend(Symbol(),OP_BUY,lotMM,Ask,Slippage,myStopLoss,myTakeProfit,setup,MagicNumber,0,Green); 
   if(ticket<=0)
   {
      err = GetLastError();
      Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); 
   }
}

//+------------------------------------------------------------------+
//| OpenSellOrder                                                    |
//| If Stop Loss or TakeProfit are used the values are calculated    |
//| for each trade                                                   |
//+------------------------------------------------------------------+
void OpenSellOrder()
{
   int err, ticket;
   double myStopLoss = 0, myTakeProfit = 0;
   
   myStopLoss = 0;
   if ( StopLoss > 0 ) myStopLoss = Bid + StopLoss * Point;
   myTakeProfit = 0;
   if (TakeProfit > 0) myTakeProfit = Bid - TakeProfit * Point;
   ticket=OrderSend(Symbol(),OP_SELL,lotMM,Bid,Slippage,myStopLoss,myTakeProfit,setup,MagicNumber,0,Red); 
   if(ticket<=0)
   {
      err = GetLastError();
      Print("Error opening Sell order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); 
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
      if ( OrderMagicNumber() != MagicNumber)  continue;
      
      if(OrderType() == OP_BUY )  NumBuyTrades++;
      if(OrderType() == OP_SELL ) NumSellTrades++;
             
     }
     NumPositions = NumBuyTrades + NumSellTrades;
     return (NumPositions);
  }


//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//+------------------------------------------------------------------+
int HandleOpenPositions()
{
   int cnt;
   bool YesClose;
   double pt;
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MagicNumber)  continue;
      
      if(OrderType() == OP_BUY)
      {
            
         if (CheckExitCondition("BUY"))
          {
               CloseOrder(OrderTicket(),OrderLots(),Bid);
          }
          else
          {
            if (UseTrailingStop)
            {
               HandleTrailingStop("BUY",OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
            }
          }
      }

      if(OrderType() == OP_SELL)
      {
          if (CheckExitCondition("SELL"))
          {
             CloseOrder(OrderTicket(),OrderLots(),Ask);
          }
          else
          {
             if(UseTrailingStop)  
             {                
               HandleTrailingStop("SELL",OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
             }
          }
       }
   }
}

//+------------------------------------------------------------------+
//| Close Open Position Controls                                     |
//|  Try to close position 3 times                                   |
//+------------------------------------------------------------------+
void CloseOrder(int ticket,double numLots,double close_price)
{
   int CloseCnt, err;
   
   // try to close 3 Times
      
    CloseCnt = 0;
    while (CloseCnt < 3)
    {
       if (OrderClose(ticket,numLots,close_price,Slippage,Violet))
       {
         CloseCnt = 3;
       }
       else
       {
         err=GetLastError();
         Print(CloseCnt," Error closing order : (", err , ") " + ErrorDescription(err));
         if (err > 0) CloseCnt++;
       }
    }
}

//+------------------------------------------------------------------+
//| Modify Open Position Controls                                    |
//|  Try to modify position 3 times                                  |
//+------------------------------------------------------------------+
void ModifyOrder(int ord_ticket,double op, double price,double tp)
{
    int CloseCnt, err;
    
    CloseCnt=0;
    while (CloseCnt < 3)
    {
       if (OrderModify(ord_ticket,op,price,tp,0,Aqua))
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

//+------------------------------------------------------------------+
//| HandleTrailingStop                                               |
//| Type 1 moves the stoploss without delay.                         |
//| Type 2 waits for price to move the amount of the trailStop       |
//| before moving stop loss then moves like type 1                   |
//| Type 3 uses up to 3 levels for trailing stop                     |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//| Possible future types                                            |
//| Type 4 uses 2 for 1, every 2 pip move moves stop 1 pip           |
//| Type 5 uses 3 for 1, every 3 pip move moves stop 1 pip           |
//+------------------------------------------------------------------+
int HandleTrailingStop(string type, int ticket, double op, double os, double tp)
{
    double pt, TS=0;
    double bos,bop,opa,osa;
    
    if (type == "BUY")
    {
       switch(TrailingStopType)
       {
        case 1: pt = Point*StopLoss;
                if(Bid-os > pt) ModifyOrder(ticket,op,Bid-pt,tp);
                break;
        case 2: pt = Point*TrailingStop;
                if(Bid-op > pt && os < Bid - pt) ModifyOrder(ticket,op,Bid - pt,tp);
                break;
        case 3: if (Bid - op > FirstMove * Point)
                {
                   TS = op + FirstMove*Point - FirstStopLoss * Point;
                   if (os < TS)
                   {
                    ModifyOrder(ticket,op,TS,tp);
                   }
                }
                 
                if (Bid - op > SecondMove * Point)
                {
                   TS = op + SecondMove*Point - SecondStopLoss * Point;
                   if (os < TS)
                   {
                    ModifyOrder(ticket,op,TS,tp);
                   }
                }
                 
                if (Bid - op > ThirdMove * Point)
                {
                   TS = Bid  - TrailingStop3*Point;
                   if (os < TS)
                   {
                     ModifyOrder(ticket,op,TS,tp);
                   }
                }
                break;
       }
       return(0);
    }
       
    if (type ==  "SELL")
    {
       switch(TrailingStopType)
       {
        case 1: pt = Point*StopLoss;
                if(os - Ask > pt) ModifyOrder(ticket,op,Ask+pt,tp);
                break;
        case 2: pt = Point*TrailingStop;
                if(op - Ask > pt && os > Ask+pt) ModifyOrder(ticket,op,Ask+pt,tp);
                break;
        case 3: if (op - Ask > FirstMove * Point)
                {
                   TS = op - FirstMove * Point + FirstStopLoss * Point;
                   if (os > TS)
                   {
                    ModifyOrder(ticket,op,TS,tp);
                   }
                }
                if (op - Ask > SecondMove * Point)
                {
                   TS = op - SecondMove * Point + SecondStopLoss * Point;
                   if (os > TS)
                   {
                    ModifyOrder(ticket,op,TS,tp);
                   }
                }
                if (op - Ask > ThirdMove * Point)
                {
                  TS = Ask + TrailingStop3 * Point;               
                  if (os > TS)
                  {
                    ModifyOrder(ticket,op,TS,tp);
                  }
                }
                break;
       }
    }
    return(0);
}

//+------------------------------------------------------------------+
//| Get number of lots for this trade                                |
//+------------------------------------------------------------------+
double GetLots()
{
   double lot;
   
   if(MoneyManagement)
   {
     lot = LotsOptimized();
   }
   else {
     lot = Lots;
     if(AccountIsMini)
     {
       if (lot > 1.0) lot = lot / 10;
       if (lot < 0.1) lot = 0.1;
     }
   }
   return(lot);
}


//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+

double LotsOptimized()
  {
   double lot=Lots;
//---- select lot size
   lot=NormalizeDouble(MathFloor(AccountFreeMargin()*TradeSizePercent/10000)/10,1);
   
  
  // lot at this point is number of standard lots
  
//  if (Debug) Print ("Lots in LotsOptimized : ",lot);
  
  // Check if mini or standard Account
  
  if(AccountIsMini)
  {
    lot = MathFloor(lot*10)/10;
    
// Use at least 1 mini lot

   if(lot<0.1) lot=0.1;
   if (lot > MaxLots) lot = MaxLots;

  }else
  {
    if (lot < 1.0) lot = 1.0;
    if (lot > MaxLots) lot = MaxLots;
  }

   return(lot);
  }
//+------------------------------------------------------------------+
//| CheckValidUserInputs                                             |
//| Check if User Inputs are valid for ranges allowed                |
//| return true if invalid input, false otherwise                    |
//| Also display an alert for invalid input                          |
//+------------------------------------------------------------------+
bool CheckValidUserInputs()
{
   if (CheckMAMethod(FastMA_Mode))
   {
     Alert("FastMA_Mode(0 to 4) You entered ",FastMA_Mode);
     return(true);
   }
   if (CheckMAMethod(SlowMA_Mode))
   {
     Alert("SlowMA_Mode(0 to 4) You entered ",SlowMA_Mode);
     return(true);
   }
   if (CheckAppliedPrice(FastMA_AppliedPrice))
   {
     Alert("FastMA_AppliedPrice( 0 to 6) You entered ",FastMA_AppliedPrice);
     return(true);
   }
   if (CheckAppliedPrice(SlowMA_AppliedPrice))
   {
     Alert("SlowMA_AppliedPrice(0 to 6) You entered ",SlowMA_AppliedPrice);
     return(true);
   }

   if (CheckTrailingStopType(TrailingStopType))
   {
     Alert("TrailingStopType( 1 to 3) You entered ",TrailingStopType);
     return(true);
   }
   
}

//+------------------------------------------------+
//| Check for valid Moving Average methods         |
//|  0=sma, 1=ema, 2=smma, 3=lwma , 3=lsma         |
//|  return true if invalid, false if OK           |
//+------------------------------------------------+
bool CheckMAMethod(int method)
{
   if (method < 0) return (true);
   if (method > 4) return (true);
   return(false);
}

//+-----------------------------------------------------+
//| Check for valid Applied Price enumerations          |
//|   0=close, 1=open, 2=high, 3=low, 4=median((h+l/2)) |
//|   5=typical((h+l+c)/3), 6=weighted((h+l+c+c)/4)     |
//|  return true if invalid, false if OK                |
//+-----------------------------------------------------+
bool CheckAppliedPrice(int applied_price)
{
   if (applied_price < 0) return (true);
   if (applied_price > 6) return (true);
   return(false);
}

//+------------------------------------------------+
//| Check for valid TrailingStopType               |
//|  |
//|  return true if invalid, false if OK           |
//+------------------------------------------------+
bool CheckTrailingStopType(int stop_type)
{
   if (stop_type < 0 ) return(true);
   if (stop_type > 3) return(true);
     return(false);

}




