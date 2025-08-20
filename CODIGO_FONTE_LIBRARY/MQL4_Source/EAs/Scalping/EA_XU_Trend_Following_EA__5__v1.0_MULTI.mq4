#property copyright "Matt Todorovski 2025"
#property link      "https://x.ai"
#property description "Shared as freeware in Free Forex Robots on Telegram"
#property version   "1.06"
#property strict

input double LotSize = 0.1;
input int FastMAPeriod = 15;
input int SlowMAPeriod = 20;
input int ADXPeriod = 14;
input double ADXThreshold = 25.0;
input int ATRPeriod = 14;
input double ATRMultiplierSL = 2.0;
input double ATRMultiplierTP = 4.0;
input int Slippage = 3;
input string TradeComment = "XU Trend Following EA";
input int MagicNumber = 202503221;
input double MaxDailyLossPercent = 5.0;
input double TrailingStopPoints = 150;

double fastMA, slowMA, prevFastMA, prevSlowMA, adx, atr;
double dailyLoss = 0.0;

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   if(!IsNewDay()) dailyLoss = CalculateDailyLoss();
   if(dailyLoss <= -AccountBalance() * MaxDailyLossPercent / 100.0) return;

   if(CountOrders() > 0) 
   {
      ManageTrailingStop();
      return;
   }

   datetime currentTime = TimeCurrent();
   int hour = TimeHour(currentTime);
   if(hour < 14 || hour > 20) return;

   fastMA = iMA(NULL, PERIOD_M5, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   slowMA = iMA(NULL, PERIOD_M5, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 0);
   prevFastMA = iMA(NULL, PERIOD_M5, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   prevSlowMA = iMA(NULL, PERIOD_M5, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, 1);
   adx = iADX(NULL, PERIOD_M5, ADXPeriod, PRICE_CLOSE, MODE_MAIN, 0);
   atr = iATR(NULL, PERIOD_M5, ATRPeriod, 0);

   if(atr < iATR(NULL, PERIOD_M5, ATRPeriod, 1)) return;

   double bid = Bid;
   double ask = Ask;

   if(fastMA > slowMA && prevFastMA <= prevSlowMA && bid <= fastMA && adx > ADXThreshold)
   {
      double sl = bid - (atr * ATRMultiplierSL);
      double tp = ask + (atr * ATRMultiplierTP);
      
      int ticket = OrderSend(Symbol(), OP_BUY, LotSize, ask, Slippage, 
                           sl, tp, TradeComment, MagicNumber, 0, clrGreen);
                           
      if(ticket < 0)
         Print("OrderSend failed with error #", GetLastError());
   }

   if(fastMA < slowMA && prevFastMA >= prevSlowMA && ask >= fastMA && adx > ADXThreshold)
   {
      double sl = ask + (atr * ATRMultiplierSL);
      double tp = bid - (atr * ATRMultiplierTP);
      
      int ticket = OrderSend(Symbol(), OP_SELL, LotSize, bid, Slippage, 
                           sl, tp, TradeComment, MagicNumber, 0, clrRed);
                           
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

void ManageTrailingStop()
{
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(OrderType() == OP_BUY)
            {
               if(Bid - OrderOpenPrice() > TrailingStopPoints * Point)
               {
                  double newSL = Bid - TrailingStopPoints * Point;
                  if(newSL > OrderStopLoss())
                  {
                     bool modified = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrGreen);
                     if(!modified)
                        Print("OrderModify failed for Buy order with error #", GetLastError());
                  }
               }
            }
            else if(OrderType() == OP_SELL)
            {
               if(OrderOpenPrice() - Ask > TrailingStopPoints * Point)
               {
                  double newSL = Ask + TrailingStopPoints * Point;
                  if(newSL < OrderStopLoss() || OrderStopLoss() == 0)
                  {
                     bool modified = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrRed);
                     if(!modified)
                        Print("OrderModify failed for Sell order with error #", GetLastError());
                  }
               }
            }
         }
      }
   }
}

bool IsNewDay()
{
   static datetime lastDay = 0;
   datetime currentDay = TimeCurrent() / 86400;
   if(currentDay != lastDay)
   {
      lastDay = currentDay;
      return true;
   }
   return false;
}

double CalculateDailyLoss()
{
   double loss = 0.0;
   for(int i = 0; i < OrdersHistoryTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(TimeDayOfYear(OrderCloseTime()) == TimeDayOfYear(TimeCurrent()))
               loss += OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
   }
   return loss;
}