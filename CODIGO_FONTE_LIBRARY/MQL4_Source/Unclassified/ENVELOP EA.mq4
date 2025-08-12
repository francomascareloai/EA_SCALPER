//+------------------------------------------------------------------+
//|                                                   ENVELOP EA.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#property copyright "Automation fx"
#property link      "https://sites.google.com/view/automationfx/home"
#property version   "1.00"
#property strict
#define buy 2
#define sell -2

//+------------------------------------------------------------------+
//| Expert inputs                                                    
//+------------------------------------------------------------------+
extern string __Afx1="------open for buy sell trades----------------------------";
input bool                  CloseBySignal              = True; 
input bool                  OpenBUY                    = True;   
input bool                  OpenSELL                   = True; 

input string  Indicator1  ="==Envolope Indicator settings==";

extern bool                 use_Envolop=true;
input int                   I_Period                   =  25; // Period
input double                I_Deviation                =  0.35; // Deviation 
 
extern string __Afx3="-----------trade  settings-----------------------";

input double                  LotSize                   = 0.1;  // Lot size
input double                  StopLoss                  = 0;   // Stop loss level (in pips)
input double                  TakeProfit                = 0; // Take profit level (in pips)
input double                  TrailingStop              = 0; // Trailing stop level (in pips)
input int                     MagicNumber               = 122354; // Magic number for order managment
input int                     Slippage                  = 10; // Maximum allowed slippage
input string                  comment                   = "AFX ENVO";
//--------------------variables-----------------------------------------------+
datetime dt;
const double    F_away          = 0.000001; 
int OrderBuy,OrderSell; // Number of open buy/sell orders
int ticket; // Order ticket
int LotDigits; // Number of digits in the lot size
double Trail,iTrailingStop; // Trailing stop variables


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
int start()
  {  
    double stoplevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
    OrderBuy = 0;
    OrderSell = 0;
    for (int cnt = 0; cnt < OrdersTotal(); cnt++)
    {
        if (OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderComment() == comment)
            {
                if (OrderType() == OP_BUY)
                {
                    OrderBuy++;
                }
                if (OrderType() == OP_SELL)
                {
                    OrderSell++;
                }
                if (TrailingStop > 0)
                {
                    iTrailingStop = TrailingStop;
                    if (TrailingStop < stoplevel)
                    {
                        iTrailingStop = stoplevel;
                    }
                    Trail = iTrailingStop * Point;
                    double tsbuy = NormalizeDouble(Bid - Trail, Digits);
                    double tssell = NormalizeDouble(Ask + Trail, Digits);

                    if (OrderType() == OP_BUY && Bid - OrderOpenPrice() > Trail && Bid - OrderStopLoss() > Trail)
                    {
                        ticket = OrderModify(OrderTicket(), OrderOpenPrice(), tsbuy, OrderTakeProfit(), 0, Blue);
                    }

                    if (OrderType() == OP_SELL && OrderOpenPrice() - Ask > Trail && (OrderStopLoss() - Ask > Trail || OrderStopLoss() == 0))
                    {
                        ticket = OrderModify(OrderTicket(), OrderOpenPrice(), tssell, OrderTakeProfit(), 0, Blue);
                    }
                }
            }
        }
    }
   if(isnewbar())
     {
            // Open position if conditions match
            if (OpenSELL && OrderSell < 1 && signal() == sell) OPSELL();
            if (OpenBUY && OrderBuy < 1 && signal() == buy) OPBUY();

            // Close position by signal
            if (CloseBySignal) {
                if (OrderBuy > 0 &&  signal() == sell) CloseBuy();
                if (OrderSell > 0 && signal() == buy) CloseSell();
    }
    }
    // Return 0 to indicate successful execution of start function
    return(0);
}
//----------
//+------------------------------------------------------------------+
void OPBUY()
  {
  
   double StopLossLevel;
   double TakeProfitLevel;
  // Calculate the stop loss and take profit levels based on input values
   if(StopLoss>0) StopLossLevel=Bid-StopLoss*Point; else StopLossLevel=0.0;
   if(TakeProfit>0) TakeProfitLevel=Ask+TakeProfit*Point; else TakeProfitLevel=0.0;
// Send a buy order with the calculated stop loss and take profit levels
     ticket=OrderSend(Symbol(),OP_BUY,LotSize,Ask,Slippage,StopLossLevel,TakeProfitLevel,comment,MagicNumber,0,Blue);
     
  }
//--------------------------------------------------------------------------------------------------------------------------+
void OPSELL()
  {
   double StopLossLevel;
   double TakeProfitLevel;
   if(StopLoss>0) StopLossLevel=Ask+StopLoss*Point; else StopLossLevel=0.0;
   if(TakeProfit>0) TakeProfitLevel=Bid-TakeProfit*Point; else TakeProfitLevel=0.0;
//---
   ticket=OrderSend(Symbol(),OP_SELL,LotSize,Bid,Slippage,StopLossLevel,TakeProfitLevel,comment,MagicNumber,0,Red);
  }
//------------------------------------------------------------------------------------------------------------------------+
void CloseBuy()
  {
   int  total=OrdersTotal();// get the total number of orders
   for(int y=OrdersTotal()-1; y>=0; y--) // iterate over all orders starting from the most recent one
    
     { 
                if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))// select an order by its position
        // check if the order is a BUY order, for the same symbol and magic number as specified in the input parameters
         if(OrderSymbol()==Symbol() && OrderType()==OP_BUY && OrderMagicNumber()==MagicNumber)
           {
            ticket=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Black);
           }
     }
  }
  //------------------------------------------------------------------------------------------------------------+
  void CloseSell()
  {
   int  total=OrdersTotal();
   for(int y=OrdersTotal()-1; y>=0; y--)
     {
      if(OrderSelect(y,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderType()==OP_SELL && OrderMagicNumber()==MagicNumber)
           {
            ticket=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),5,Black);
           }
     }
  }
 //--------------------------------------------------------------------------------------+
//check if is new bar
 bool isnewbar(){
   if(Time[0] != dt){
      dt = Time[0];
      return true;
   }
   return false;
}  


//----------------------------------------------------------------------+   
int signal()
{
  // Envelopes (
   double I_UPBand  = iEnvelopes(NULL, 0, I_Period, MODE_SMA, 0, PRICE_CLOSE, I_Deviation, MODE_UPPER, 1);
   double I_LOBand  = iEnvelopes(NULL, 0, I_Period, MODE_SMA, 0, PRICE_CLOSE, I_Deviation, MODE_LOWER, 1);
   double I_UPBand1 = iEnvelopes(NULL, 0, I_Period, MODE_SMA, 0, PRICE_CLOSE, I_Deviation, MODE_UPPER, 2);
   double I_LOBand1 = iEnvelopes(NULL, 0, I_Period, MODE_SMA, 0, PRICE_CLOSE, I_Deviation, MODE_LOWER, 2);
   
   if (use_Envolop) 
   {
   
      if (Open(0) < I_LOBand - F_away && Open(1) > I_LOBand1 + F_away)  return(buy);
      if (Open(0) > I_UPBand + F_away && Open(1) < I_UPBand1 - F_away) return(sell);

   } 
  return(0);
}
//----------------------------------------------------------------------------------------------------+
double Open(int bar)
  {
   return Open[bar];
  }
//-