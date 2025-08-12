//+------------------------------------------------------------------+
//|                         Simple Expert Advisor with Functions.mq4 |
//|                                                  Andrew R. Young |
//|                                 http://www.expertadvisorbook.com |
//+------------------------------------------------------------------+
#property copyright   "Andrew R. Young"
#property link        "http://www.expertadvisorbook.com"
#property description "Same as Simple Expert Advisor, but using functions from Trade.mqh"
#property strict


// Include and objects
#include <Mql4Book\Trade.mqh>
CTrade Trade;
CCount Count;


// Input variables
input int MagicNumber = 101;
input int Slippage = 10;

input double LotSize = 0.1;
input int StopLoss = 0;
input int TakeProfit = 0;

input int MaPeriod = 5;
input ENUM_MA_METHOD MaMethod = MODE_EMA;
input ENUM_APPLIED_PRICE MaPrice = PRICE_CLOSE;


// Global variables
int gBuyTicket, gSellTicket;


// OnInit() event handler
int OnInit()
{
   // Set magic number
   Trade.SetMagicNumber(MagicNumber);
   Trade.SetSlippage(Slippage);
   
   return(INIT_SUCCEEDED);
}


// OnTick() event handler
void OnTick()
{

   // Moving average and close price from last bar
   double ma = iMA(_Symbol,_Period,MaPeriod,0,MaMethod,MaPrice,1);
   double close = Close[1];
   
   
   // Buy order condition
   if(close > ma && Count.Buy() == 0 && gBuyTicket == 0)
   {
      // Close sell order(s)
      Trade.CloseAllSellOrders();
      
      // Open buy order
      gBuyTicket = Trade.OpenBuyOrder(_Symbol,LotSize);
      gSellTicket = 0;
      
      // Add stop loss & take profit to order
      ModifyStopsByPoints(gBuyTicket,StopLoss,TakeProfit);
   }
   
   
   // Sell order condition
   if(close < ma && Count.Sell() == 0 && gSellTicket == 0)
   {
      // Close buy order(s)
      Trade.CloseAllBuyOrders();
      
      // Open sell order
      gSellTicket = Trade.OpenSellOrder(_Symbol,LotSize);
      gBuyTicket = 0;
      
      // Add stop loss & take profit to order
      ModifyStopsByPoints(gSellTicket,StopLoss,TakeProfit);
   }
   
}