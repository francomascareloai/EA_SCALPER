//+------------------------------------------------------------------+
//|                                              Test Scalper EA.mq4 |
//|                        Copyright 2025, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// Input parameters
input double LotSize = 0.01;
input int StopLoss = 20;
input int TakeProfit = 60;
input int MagicNumber = 12345;
input bool UseRiskManagement = true;
input double MaxRiskPercent = 1.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("Scalper EA initialized");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Simple scalping logic
   double ma_fast = iMA(Symbol(), PERIOD_M5, 10, 0, MODE_SMA, PRICE_CLOSE, 0);
   double ma_slow = iMA(Symbol(), PERIOD_M5, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   
   if(ma_fast > ma_slow && OrdersTotal() == 0)
   {
      double lot = UseRiskManagement ? CalculateLotSize() : LotSize;
      OrderSend(Symbol(), OP_BUY, lot, Ask, 3, Ask - StopLoss * Point, Ask + TakeProfit * Point, "Scalper Buy", MagicNumber, 0, clrGreen);
   }
   
   if(ma_fast < ma_slow && OrdersTotal() == 0)
   {
      double lot = UseRiskManagement ? CalculateLotSize() : LotSize;
      OrderSend(Symbol(), OP_SELL, lot, Bid, 3, Bid + StopLoss * Point, Bid - TakeProfit * Point, "Scalper Sell", MagicNumber, 0, clrRed);
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk management                     |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   double balance = AccountBalance();
   double riskAmount = balance * MaxRiskPercent / 100.0;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double lotSize = riskAmount / (StopLoss * tickValue);
   
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                               |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("Scalper EA deinitialized");
}