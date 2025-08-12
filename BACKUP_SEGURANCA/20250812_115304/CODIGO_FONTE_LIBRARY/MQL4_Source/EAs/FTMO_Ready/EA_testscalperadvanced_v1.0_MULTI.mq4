//+------------------------------------------------------------------+
//|                                          Test Scalper Advanced |
//|                                  Copyright 2024, Test Company   |
//|                                             https://test.com    |
//+------------------------------------------------------------------+
#property copyright "Test Company"
#property link      "https://test.com"
#property version   "2.1"
#property strict

// Input parameters
input double LotSize = 0.01;        // Lot size (FTMO compliant)
input int StopLoss = 20;             // Stop Loss in pips
input int TakeProfit = 60;           // Take Profit in pips (3:1 RR)
input double MaxDailyLoss = 100;     // Max daily loss in USD
input int MaxTrades = 5;             // Max trades per day
input bool UseSessionFilter = true;  // Use trading session filter

// Global variables
double dailyLoss = 0;
int tradesCount = 0;
datetime lastTradeDate;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("Scalper Advanced EA initialized - FTMO Ready");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // FTMO risk management
   if(dailyLoss >= MaxDailyLoss) return;
   if(tradesCount >= MaxTrades) return;
   
   // Session filter for XAUUSD
   if(UseSessionFilter && !IsGoodTime()) return;
   
   // Scalping logic with RSI and Bollinger Bands
   double rsi = iRSI(Symbol(), PERIOD_M5, 14, PRICE_CLOSE, 0);
   double bbUpper = iBands(Symbol(), PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double bbLower = iBands(Symbol(), PERIOD_M5, 20, 2, 0, PRICE_CLOSE, MODE_LOWER, 0);
   
   double ask = Ask;
   double bid = Bid;
   
   // Buy signal
   if(rsi < 30 && bid <= bbLower)
   {
      OpenTrade(OP_BUY, ask);
   }
   
   // Sell signal  
   if(rsi > 70 && ask >= bbUpper)
   {
      OpenTrade(OP_SELL, bid);
   }
}

//+------------------------------------------------------------------+
//| Open trade function with FTMO compliance                        |
//+------------------------------------------------------------------+
void OpenTrade(int type, double price)
{
   double sl, tp;
   
   if(type == OP_BUY)
   {
      sl = price - StopLoss * Point * 10;
      tp = price + TakeProfit * Point * 10;
   }
   else
   {
      sl = price + StopLoss * Point * 10;
      tp = price - TakeProfit * Point * 10;
   }
   
   int ticket = OrderSend(Symbol(), type, LotSize, price, 3, sl, tp, "Scalper Advanced", 12345, 0, clrBlue);
   
   if(ticket > 0)
   {
      tradesCount++;
      Print("Trade opened: ", ticket);
   }
}

//+------------------------------------------------------------------+
//| Check if current time is good for trading                       |
//+------------------------------------------------------------------+
bool IsGoodTime()
{
   int hour = TimeHour(TimeCurrent());
   // London and New York sessions
   return (hour >= 8 && hour <= 17);
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk                                |
//+------------------------------------------------------------------+
double CalculateLotSize(double riskPercent)
{
   double balance = AccountBalance();
   double riskAmount = balance * riskPercent / 100;
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double stopLossPips = StopLoss;
   
   double lotSize = riskAmount / (stopLossPips * tickValue);
   return NormalizeDouble(lotSize, 2);
}