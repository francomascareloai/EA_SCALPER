#property copyright "Matt Todorovski 2025"
#property link      "https://x.ai"
#property description "Shared as freeware in Free Forex Robots on Telegram"
#property version   "1.06"
#property strict

input double LotSize = 0.1;
input int FastMAPeriod = 20;
input int SlowMAPeriod = 50;
input int StopLoss = 300;
input int TakeProfit = 600;
input int Slippage = 3;
input string TradeComment = "XU Trend Following EA";
input int MagicNumber = 202503221;

double fastMA, slowMA, prevFastMA, prevSlowMA;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   if(CountOrders() > 0) return;
   
   datetime currentTime = TimeCurrent();
   int hour = TimeHour(currentTime);
   
   if(hour < 14 || hour > 20) return;
   
   fastMA = iMA(NULL, PERIOD_M5, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   slowMA = iMA(NULL, PERIOD_M5, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   prevFastMA = iMA(NULL, PERIOD_M5, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   prevSlowMA = iMA(NULL, PERIOD_M5, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   
   double bid = Bid;
   double ask = Ask;
   
   if(fastMA > slowMA && prevFastMA <= prevSlowMA && bid <= fastMA)
   {
      double sl = bid - StopLoss * Point;
      double tp = ask + TakeProfit * Point;
      
      int ticket = OrderSend(Symbol(), OP_BUY, LotSize, ask, Slippage, 
                           sl, tp, "XAUUSD EA Buy", MagicNumber, 0, clrGreen);
                           
      if(ticket < 0)
         Print("OrderSend failed with error #", GetLastError());
   }
   
   if(fastMA < slowMA && prevFastMA >= prevSlowMA && ask >= fastMA)
   {
      double sl = ask + StopLoss * Point;
      double tp = bid - TakeProfit * Point;
      
      int ticket = OrderSend(Symbol(), OP_SELL, LotSize, bid, Slippage, 
                           sl, tp, "XAUUSD EA Sell", MagicNumber, 0, clrRed);
                           
      if(ticket < 0)
         Print("OrderSend failed with error #", GetLastError());
   }
}

int CountOrders()
{
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            count++;
      }
   }
   return count;
}